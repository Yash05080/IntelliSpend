package utils

import (
    "fmt"
    "os"
    "time"

    "github.com/golang-jwt/jwt/v5"
)

// GenerateJWT creates a signed JWT containing user ID
func GenerateJWT(userID uint) (string, error) {
    secret := []byte(os.Getenv("JWT_SECRET"))
    expireHours := os.Getenv("JWT_EXPIRE_HOURS")
    dur, _ := time.ParseDuration(expireHours + "h")

    claims := jwt.MapClaims{
        "user_id": userID,
        "exp":     time.Now().Add(dur).Unix(),
        "iat":     time.Now().Unix(),
    }
    token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
    return token.SignedString(secret)
}

// ValidateJWT parses and validates a token, returning userID
func ValidateJWT(tokenStr string) (uint, error) {
    secret := []byte(os.Getenv("JWT_SECRET"))
    token, err := jwt.Parse(tokenStr, func(t *jwt.Token) (interface{}, error) {
        if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
            return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
        }
        return secret, nil
    })
    if err != nil || !token.Valid {
        return 0, fmt.Errorf("invalid token: %v", err)
    }

    claims := token.Claims.(jwt.MapClaims)
    uid := uint(claims["user_id"].(float64))
    return uid, nil
}