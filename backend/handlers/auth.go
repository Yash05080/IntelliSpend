package handlers

import (
	"fmt"
	"math/rand"
	"net/http"
	"time"

	"backend/models"
	"backend/utils"

	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"
)

var otpStore = make(map[string]string)       // email -> OTP
var userStore = make(map[string]models.User) // active users

// Login endpoint: expects JSON {email, password}
func Login(c *gin.Context) {
	var loginData struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	if err := c.ShouldBindJSON(&loginData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	user, exists := userStore[loginData.Email]
	if !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "Account does not exist"})
		return
	}

	// Compare the hashed password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(loginData.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Incorrect password"})
		return
	}

	token, err := utils.GenerateJWT(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token})
}

// Register endpoint: expects JSON {fullName, phone, email, password}
func Register(c *gin.Context) {
	var regData struct {
		FullName string `json:"fullName"`
		Phone    string `json:"phone"`
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	if err := c.ShouldBindJSON(&regData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	if _, exists := userStore[regData.Email]; exists {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Account already exists"})
		return
	}

	// Generate OTP and store it
	otp := generateOTP()
	otpStore[regData.Email] = otp

	// Hash password and store user in PendingUsers (waiting for OTP verification)
	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(regData.Password), bcrypt.DefaultCost)
	user := models.User{
		FullName:  regData.FullName,
		Phone:     regData.Phone,
		Email:     regData.Email,
		Password:  string(hashedPassword),
		CreatedAt: time.Now(),
	}
	models.PendingUsers[regData.Email] = user

	// Send OTP email instead of returning it in the response
	body := fmt.Sprintf("Your IntelliSpend OTP is: %s. It expires in 10 minutes.", otp)
	if err := utils.SendEmail(user.Email, "Your OTP Code", body); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send OTP email"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "OTP sent to email"})
}

// VerifyOTP endpoint: expects JSON {email, otp}
func VerifyOTP(c *gin.Context) {
	var otpData struct {
		Email string `json:"email"`
		OTP   string `json:"otp"`
	}
	if err := c.ShouldBindJSON(&otpData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	expectedOTP, exists := otpStore[otpData.Email]
	if !exists || expectedOTP != otpData.OTP {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid OTP"})
		return
	}

	user, exists := models.PendingUsers[otpData.Email]
	if !exists {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No pending registration found"})
		return
	}
	// Move user to active store and clear pending/OTP
	userStore[otpData.Email] = user
	delete(models.PendingUsers, otpData.Email)
	delete(otpStore, otpData.Email)

	token, err := utils.GenerateJWT(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token})
}

func generateOTP() string {
	rand.Seed(time.Now().UnixNano())
	return fmt.Sprintf("%06d", rand.Intn(1000000))
}
