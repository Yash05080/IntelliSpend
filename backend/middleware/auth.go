package middleware

import (
	"backend/utils"
	"net/http"

	"github.com/gin-gonic/gin"
)

// AuthRequired validates the JWT and sets user_id in the Gin context.
func AuthRequired() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Missing Authorization header"})
			return
		}

		// Expect header value in format "Bearer <token>"
		tokenStr := authHeader[len("Bearer "):]
		userID, err := utils.ValidateJWT(tokenStr)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
			return
		}

		c.Set("user_id", userID)
		c.Next()
	}
}
