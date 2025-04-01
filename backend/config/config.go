package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

// Load environment variables
func LoadConfig() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}
}

// GetEnv fetches environment variables
func GetEnv(key string) string {
	return os.Getenv(key)
}
