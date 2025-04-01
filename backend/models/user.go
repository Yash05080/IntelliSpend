package models

import "time"

type User struct {
	ID        int       `json:"id"`
	Email     string    `json:"email"`
	FullName  string    `json:"fullName"`
	Picture   string    `json:"picture"`
	CreatedAt time.Time `json:"createdAt"`
}

// GoogleUser struct to parse Google's response
type GoogleUser struct {
	Email     string `json:"email"`
	Name      string `json:"name"`
	Picture   string `json:"picture"`
	Audience  string `json:"aud"`
}

// Mock database (Replace with real DB integration later)
var users = []User{}

func FindOrCreateUser(googleUser *GoogleUser) User {
	for _, u := range users {
		if u.Email == googleUser.Email {
			return u
		}
	}

	newUser := User{
		ID:        len(users) + 1,
		Email:     googleUser.Email,
		FullName:  googleUser.Name,
		Picture:   googleUser.Picture,
		CreatedAt: time.Now(),
	}

	users = append(users, newUser)
	return newUser
}
