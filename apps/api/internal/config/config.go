package config

import "os"

type Config struct {
	DatabaseURL string
	Port        string
	CORSOrigin  string
}

func Load() Config {
	c := Config{
		DatabaseURL: os.Getenv("DATABASE_URL"),
		Port:        os.Getenv("PORT"),
		CORSOrigin:  os.Getenv("CORS_ORIGIN"),
	}
	if c.Port == "" {
		c.Port = "8080"
	}
	if c.CORSOrigin == "" {
		c.CORSOrigin = "http://localhost:3000"
	}
	return c
}
