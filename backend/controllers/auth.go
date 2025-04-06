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
    var req struct { Email string `json:"email"` }
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
    code := fmt.Sprintf("%06d", time.Now().UnixNano()%1000000)
    otp := models.OTP{UserID: user.ID, Code: code, ExpiresAt: time.Now().Add(10 * time.Minute)}
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
func Verify(c *gin.Context) {
    var req struct {
		Email string `json:"email"`
		OTP   string `json:"otp"`
	}
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid payload"})
        return
    }

    // Lookup user
    var user models.User
    if err := config.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found"})
        return
    }

    // Lookup OTP
    var otp models.OTP
    if err := config.DB.Where("user_id = ? AND code = ? AND used = FALSE AND expires_at > ?", user.ID, req.OTP, time.Now()).First(&otp).Error; err != nil {
        c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid or expired OTP"})
        return
    }

    // Mark OTP used
    otp.Used = true
    config.DB.Save(&otp)

    // Issue JWT
    token, err := utils.GenerateJWT(user.ID)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
        return
    }

    c.JSON(http.StatusOK, gin.H{"token": token, "user": user})
}