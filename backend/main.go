package main

import (
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"

	"backend/config"
	"backend/handlers"
	"backend/models"

	"github.com/gin-gonic/gin"
)

func main() {
	// Load environment variables from .env file
	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Error loading .env file")
	}
	fmt.Println("EMAIL_FROM:", os.Getenv("EMAIL_FROM"))
fmt.Println("EMAIL_PASS set:", os.Getenv("EMAIL_PASS") != "")


	// Connect to the database
	config.ConnectDatabase() // Ensure this initializes config.DB correctly

	// AutoMigrate your models (User and OTP)
	config.DB.AutoMigrate(&models.User{}, &models.OTP{})

	// Setup Gin router and routes
	router := gin.Default()
	auth := router.Group("/api/auth")
	{
		auth.POST("/login", handlers.Login)
		auth.POST("/register", handlers.Register)
		auth.POST("/verify-otp", handlers.VerifyOTP)
	}

	log.Fatal(router.Run(":8080"))
}
