package handler

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/simontarrant/summit-spec/apps/api/internal/model"
	"github.com/simontarrant/summit-spec/apps/api/internal/service"
)

type SearchHandler struct {
	svc *service.SearchService
}

func NewSearchHandler(svc *service.SearchService) *SearchHandler {
	return &SearchHandler{svc: svc}
}

func (h *SearchHandler) Search(w http.ResponseWriter, r *http.Request) {
	var req model.SearchRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		writeError(w, http.StatusBadRequest, "Invalid request body")
		return
	}

	if req.CategoryID == "" {
		writeError(w, http.StatusBadRequest, "Invalid or missing categoryId")
		return
	}

	resp, err := h.svc.Search(r.Context(), req)
	if err != nil {
		log.Printf("search error: %v", err)
		writeError(w, http.StatusInternalServerError, "Internal server error")
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func writeError(w http.ResponseWriter, status int, msg string) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(map[string]string{"error": msg})
}
