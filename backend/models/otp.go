package models

import (
    "time"
    "gorm.io/gorm"
)

type OTP struct {
    gorm.Model
    UserID    uint      `json:"userId"`
    Email     string    `gorm:"index" json:"email"` // ✅ Add this line
    Code      string    `json:"code"`
    ExpiresAt time.Time `json:"expiresAt"`
}
