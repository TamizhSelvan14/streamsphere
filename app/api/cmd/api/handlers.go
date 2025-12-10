package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
)

type PresignRequest struct {
	Filename string `json:"filename"`
}

type PresignResponse struct {
	URL      string    `json:"url"`
	VideoID  string    `json:"video_id"`
	ExpireAt time.Time `json:"expire_at"`
}

type DBSecret struct {
	Username string `json:"username"`
	Password string `json:"password"`
	Host     string `json:"host"`
	Port     int    `json:"port"`
	Dbname   string `json:"dbname"`
}

func loadDBSecret() (*DBSecret, error) {
	name := os.Getenv("DB_SECRET_NAME")
	if name == "" {
		return nil, fmt.Errorf("DB_SECRET_NAME not set")
	}

	cfg, _ := config.LoadDefaultConfig(context.Background())
	sm := secretsmanager.NewFromConfig(cfg)

	out, err := sm.GetSecretValue(context.Background(),
		&secretsmanager.GetSecretValueInput{SecretId: aws.String(name)})
	if err != nil {
		return nil, err
	}

	var s DBSecret
	json.Unmarshal([]byte(*out.SecretString), &s)
	return &s, nil
}

func healthz(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"ok":true}`))
}

func presignVideo(w http.ResponseWriter, r *http.Request) {
	var req PresignRequest
	_ = json.NewDecoder(r.Body).Decode(&req)

	bucket := os.Getenv("S3_BUCKET_VIDEOS")
	if bucket == "" {
		http.Error(w, "S3_BUCKET_VIDEOS not set", http.StatusInternalServerError)
		return
	}

	cfg, err := config.LoadDefaultConfig(context.Background())
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	client := s3.NewFromConfig(cfg)
	presigner := s3.NewPresignClient(client)

	key := fmt.Sprintf("%d_%s", time.Now().UnixNano(), req.Filename)
	po := &s3.PutObjectInput{Bucket: &bucket, Key: &key}
	res, err := presigner.PresignPutObject(context.Background(), po, s3.WithPresignExpires(15*time.Minute))
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	resp := PresignResponse{URL: res.URL, VideoID: key, ExpireAt: time.Now().Add(15 * time.Minute)}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

type ConfirmRequest struct {
	VideoID string `json:"video_id"`
}

func confirmVideo(w http.ResponseWriter, r *http.Request) {
	var req ConfirmRequest
	_ = json.NewDecoder(r.Body).Decode(&req)

	if _, err := loadDBSecret(); err != nil {
		http.Error(w, "failed to load db secret", 500)
		return
	}

	// TODO: Insert/Update Aurora row, enqueue SQS message for worker, etc.
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(`{"status":"QUEUED"}`))
}

func getFeed(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(`{"videos":[{"id":"demo","title":"Hello StreamSphere"}]}`))
}
