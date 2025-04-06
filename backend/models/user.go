package models

import (
   // "time"
    "gorm.io/gorm"
)

// User represents a registered user
type User struct {
    gorm.Model
    Email     string `gorm:"unique;not null" json:"email"`
    FullName  string `json:"fullName"`
    Picture   string `json:"picture"`
    GoogleID  string `gorm:"unique" json:"googleId"` // optional for Google sign-in
    
    // Transactions relation
    Transactions []Transaction `gorm:"foreignKey:UserID"`
}