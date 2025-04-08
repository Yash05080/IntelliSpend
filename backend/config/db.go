package config

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"

	"backend/models"  // update with your module path if needed
)

var DB *gorm.DB

// ConnectDatabase connects to the PostgreSQL database and migrates models.
func ConnectDatabase() {
	err := godotenv.Load()
	if err != nil {
		log.Println("Warning: .env file not loaded:", err)
	}

	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_PORT"),
	)

	database, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}
	DB = database

	// Auto-migrate models.
	err = DB.AutoMigrate(
		&models.User{},
		&models.OTP{},
		&models.Transaction{},
	)
	if err != nil {
		log.Fatal("Failed to migrate models:", err)
	}

	fmt.Println("✅ Database connected and models migrated")
}
