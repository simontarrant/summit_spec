package handler

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHealth(t *testing.T) {
	req := httptest.NewRequest(http.MethodGet, "/health", nil)
	w := httptest.NewRecorder()

	Health(w, req)

	if w.Code != http.StatusOK {
		t.Errorf("expected 200, got %d", w.Code)
	}

	ct := w.Header().Get("Content-Type")
	if ct != "application/json" {
		t.Errorf("expected application/json, got %s", ct)
	}

	var body map[string]string
	if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil {
		t.Fatalf("invalid JSON response: %v", err)
	}
	if body["status"] != "ok" {
		t.Errorf("expected status ok, got %s", body["status"])
	}
}

func TestWriteError(t *testing.T) {
	w := httptest.NewRecorder()
	writeError(w, http.StatusBadRequest, "test error")

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", w.Code)
	}

	var body map[string]string
	if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil {
		t.Fatalf("invalid JSON: %v", err)
	}
	if body["error"] != "test error" {
		t.Errorf("expected 'test error', got '%s'", body["error"])
	}
}

func TestSearchHandler_InvalidBody(t *testing.T) {
	h := &SearchHandler{svc: nil} // svc won't be called

	req := httptest.NewRequest(http.MethodPost, "/products/search", strings.NewReader("not json"))
	w := httptest.NewRecorder()

	h.Search(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", w.Code)
	}

	var body map[string]string
	json.Unmarshal(w.Body.Bytes(), &body)
	if body["error"] != "Invalid request body" {
		t.Errorf("expected 'Invalid request body', got '%s'", body["error"])
	}
}

func TestSearchHandler_MissingCategoryID(t *testing.T) {
	h := &SearchHandler{svc: nil}

	req := httptest.NewRequest(http.MethodPost, "/products/search", strings.NewReader(`{"limit":10}`))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	h.Search(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", w.Code)
	}

	var body map[string]string
	json.Unmarshal(w.Body.Bytes(), &body)
	if body["error"] != "Invalid or missing categoryId" {
		t.Errorf("expected 'Invalid or missing categoryId', got '%s'", body["error"])
	}
}

func TestSearchHandler_EmptyCategoryID(t *testing.T) {
	h := &SearchHandler{svc: nil}

	req := httptest.NewRequest(http.MethodPost, "/products/search", strings.NewReader(`{"categoryId":""}`))
	req.Header.Set("Content-Type", "application/json")
	w := httptest.NewRecorder()

	h.Search(w, req)

	if w.Code != http.StatusBadRequest {
		t.Errorf("expected 400, got %d", w.Code)
	}
}
