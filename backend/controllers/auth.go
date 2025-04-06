package controllers

import (
	"backend/config"
	"backend/models"
	"backend/utils"

	//"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// POST /auth/register
// Body: { "email": "user@example.com" }
func Register(c *gin.Context) {
	var req struct {
		Email string `json:"email"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid email payload"})
		return
	}

	// Find or create user by email
	var user models.User
	result := config.DB.Where("email = ?", req.Email).First(&user)
	if result.Error != nil {
		user = models.User{Email: req.Email}
		config.DB.Create(&user)
	}

	// Generate OTP
	// Generate OTP
	code := fmt.Sprintf("%06d", time.Now().UnixNano()%1000000)
	otp := models.OTP{
		UserID:    user.ID,
		Email:     user.Email, // ✅ Add this line
		Code:      code,
		ExpiresAt: time.Now().Add(10 * time.Minute),
	}
	config.DB.Create(&otp)

	// Send email
	body := fmt.Sprintf("Your IntelliSpend OTP is: %s. It expires in 10 minutes.", code)
	if err := utils.SendEmail(user.Email, "Your OTP Code", body); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send OTP email"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "OTP sent to email"})
}

// POST /auth/verify
// Body: { "email": "user@example.com", "otp": "123456" }
func VerifyOTP(c *gin.Context) {
	var req struct {
		Email string `json:"email"`
		OTP   string `json:"otp"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid payload"})
		return
	}

	// Fetch OTP using email and code
	var otp models.OTP
	if err := config.DB.Where("email = ? AND code = ?", req.Email, req.OTP).First(&otp).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid OTP or email"})
		return
	}

	// ⏳ Check for expiry (based on ExpiresAt field)
	if time.Now().After(otp.ExpiresAt) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "OTP expired"})
		return
	}

	// ✅ OTP is valid, continue with login/registration flow
	var user models.User
	if err := config.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		// Create new user if not exists
		user = models.User{
			Email: req.Email,
		}
		config.DB.Create(&user)
	}

	// 🧹 Delete used OTP
	config.DB.Delete(&otp)

	// 🔐 Generate JWT
	// After token generation
	token, _ := utils.GenerateJWT(user.ID)

	c.JSON(http.StatusOK, gin.H{
		"message": "OTP verified successfully",
		"token":   token,
		"user": gin.H{
			"id":       user.ID,
			"email":    user.Email,
			"fullName": user.FullName,
			"picture":  user.Picture,
		},
		"expiresIn": 3600 * 24, // e.g., if JWT is set to expire in 24h
	})

}
