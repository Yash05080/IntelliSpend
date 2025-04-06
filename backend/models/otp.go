package models

import (
    "time"
    "gorm.io/gorm"
)

// OTP represents a one-time password for email verification/login
type OTP struct {
    gorm.Model
    UserID    uint      `json:"userId"`
    Code      string    `json:"code"`       // e.g. "123456"
    ExpiresAt time.Time `json:"expiresAt"` // expiration time
    Used      bool      `json:"used"`      // whether the OTP has been consumed
}