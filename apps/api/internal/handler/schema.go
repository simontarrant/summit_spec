package handler

import (
	"encoding/json"
	"log"
	"net/http"

	"github.com/simontarrant/summit-spec/apps/api/internal/service"
)

type SchemaHandler struct {
	svc *service.SchemaService
}

func NewSchemaHandler(svc *service.SchemaService) *SchemaHandler {
	return &SchemaHandler{svc: svc}
}

func (h *SchemaHandler) GetSchema(w http.ResponseWriter, r *http.Request) {
	resp, err := h.svc.GetSchema(r.Context())
	if err != nil {
		log.Printf("schema error: %v", err)
		writeError(w, http.StatusInternalServerError, "Internal server error")
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}
