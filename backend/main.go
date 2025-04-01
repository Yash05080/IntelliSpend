package main

import (
	"fmt"
	"backend/config"
	"backend/routes"

	"github.com/gin-gonic/gin"
)

func main() {
	// Load environment variables
	config.LoadConfig()

	// Initialize router
	router := gin.Default()

	// Register routes
	routes.RegisterRoutes(router)

	// Start server
	port := "8080"
	fmt.Println("Server running on port", port)
	router.Run(":" + port)
}
