package com.unimanager.backend.model;

import java.time.Instant;

public class StudentDocument {
    private String id;
    private String title;
    private String category;
    private String fileName;
    private Instant uploadDate;
    private boolean verified;

    public StudentDocument() {
        this.uploadDate = Instant.now();
        this.verified = true;
    }

    public StudentDocument(String id, String title, String category, String fileName, Instant uploadDate, boolean verified) {
        this.id = id;
        this.title = title;
        this.category = category;
        this.fileName = fileName;
        this.uploadDate = uploadDate != null ? uploadDate : Instant.now();
        this.verified = verified;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public Instant getUploadDate() { return uploadDate; }
    public void setUploadDate(Instant uploadDate) { this.uploadDate = uploadDate; }

    public boolean isVerified() { return verified; }
    public void setVerified(boolean verified) { this.verified = verified; }
}
