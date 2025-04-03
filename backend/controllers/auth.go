package controllers

import (
	//"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	//"time"

	"backend/config"
	"backend/models"
	"backend/utils"

	"github.com/gin-gonic/gin"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
)

var googleOauthConfig = &oauth2.Config{
	ClientID:     config.GetEnv("GOOGLE_CLIENT_ID"),
	ClientSecret: config.GetEnv("GOOGLE_CLIENT_SECRET"),
	RedirectURL:  "http://127.0.0.1:8080/auth/google/callback", // Not used in mobile apps
	Scopes:       []string{"email", "profile"},
	Endpoint:     google.Endpoint,
}

// Handle Google OAuth login from Flutter
func GoogleAuth(c *gin.Context) {
	var request struct {
		IdToken string `json:"idToken"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	// Verify ID Token with Google
	googleUser, err := verifyGoogleToken(request.IdToken)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid ID token"})
		return
	}

	// Check if user exists in DB, else create new user
	user := models.FindOrCreateUser(googleUser)

	// Generate JWT token for the user
	jwtToken, err := utils.GenerateJWT(user.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create JWT"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": jwtToken, "user": user})
}

// Verify Google ID Token
func verifyGoogleToken(idToken string) (*models.GoogleUser, error) {
	tokenInfoURL := "https://oauth2.googleapis.com/tokeninfo?id_token=" + idToken
	resp, err := http.Get(tokenInfoURL)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var googleUser models.GoogleUser
	if err := json.Unmarshal(body, &googleUser); err != nil {
		return nil, err
	}

	// Ensure the token is valid for your client
	if googleUser.Audience != config.GetEnv("GOOGLE_CLIENT_ID") {
		return nil, fmt.Errorf("invalid token audience")
	}

	return &googleUser, nil
}
