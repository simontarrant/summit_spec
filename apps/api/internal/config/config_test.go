package config

import (
	"os"
	"testing"
)

func TestLoad_Defaults(t *testing.T) {
	// Clear env vars to test defaults
	os.Unsetenv("PORT")
	os.Unsetenv("CORS_ORIGIN")
	os.Unsetenv("DATABASE_URL")

	cfg := Load()

	if cfg.Port != "8080" {
		t.Errorf("expected default port 8080, got %s", cfg.Port)
	}
	if cfg.CORSOrigin != "http://localhost:3000" {
		t.Errorf("expected default CORS origin, got %s", cfg.CORSOrigin)
	}
	if cfg.DatabaseURL != "" {
		t.Errorf("expected empty DATABASE_URL, got %s", cfg.DatabaseURL)
	}
}

func TestLoad_FromEnv(t *testing.T) {
	os.Setenv("PORT", "9090")
	os.Setenv("CORS_ORIGIN", "https://example.com")
	os.Setenv("DATABASE_URL", "postgresql://test:test@localhost/test")
	defer func() {
		os.Unsetenv("PORT")
		os.Unsetenv("CORS_ORIGIN")
		os.Unsetenv("DATABASE_URL")
	}()

	cfg := Load()

	if cfg.Port != "9090" {
		t.Errorf("expected port 9090, got %s", cfg.Port)
	}
	if cfg.CORSOrigin != "https://example.com" {
		t.Errorf("expected CORS origin https://example.com, got %s", cfg.CORSOrigin)
	}
	if cfg.DatabaseURL != "postgresql://test:test@localhost/test" {
		t.Errorf("expected DATABASE_URL from env, got %s", cfg.DatabaseURL)
	}
}
