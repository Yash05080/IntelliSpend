package main

import (
	//"fmt"
	"backend/config"
	"backend/models"
	"backend/routes"

	"github.com/gin-gonic/gin"
)

func main() {
	// Connect to Database
	config.ConnectDatabase()

	// Auto-Migrate Models
	config.DB.AutoMigrate(&models.Transaction{})

	// Set up Router
	router := gin.Default()
	routes.SetupRoutes(router)

	// Start Server
	router.Run(":8080")

	// // Load environment variables
	// config.LoadConfig()

	// // Initialize router
	// router := gin.Default()

	// // Register routes
	// routes.RegisterRoutes(router)

	// // Start server
	// port := "8080"
	// fmt.Println("Server running on port", port)
	// router.Run(":" + port)
}
