package models

import (
	"time"

	"gorm.io/gorm"
)

type User struct {
	ID        uint           `json:"id" gorm:"primaryKey"` // 👈 Add this
	FullName  string         `json:"fullName"`
	Phone     string         `json:"phone"`
	Email     string         `json:"email" gorm:"uniqueIndex"`
	Password  string         `json:"password"` // Optional for OTP-based login
	Picture   string         `json:"picture"`  // 👈 Add this if needed (e.g., Google auth profile pic)
	CreatedAt time.Time      `json:"createdAt"`
	UpdatedAt time.Time      `json:"updatedAt"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"` // optional soft-delete support
}

// Optional: In-memory store (e.g., for unverified email registrations)
var PendingUsers = make(map[string]User)
