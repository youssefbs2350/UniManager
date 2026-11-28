package com.unimanager.backend.model;

public class AcademicRecord {
    private String academicYear;
    private String level;
    private String className;
    private double average;
    private String mention;
    private String decision;

    public AcademicRecord() {}

    public AcademicRecord(String academicYear, String level, String className, double average, String mention, String decision) {
        this.academicYear = academicYear;
        this.level = level;
        this.className = className;
        this.average = average;
        this.mention = mention;
        this.decision = decision;
    }

    public String getAcademicYear() { return academicYear; }
    public void setAcademicYear(String academicYear) { this.academicYear = academicYear; }

    public String getLevel() { return level; }
    public void setLevel(String level) { this.level = level; }

    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }

    public double getAverage() { return average; }
    public void setAverage(double average) { this.average = average; }

    public String getMention() { return mention; }
    public void setMention(String mention) { this.mention = mention; }

    public String getDecision() { return decision; }
    public void setDecision(String decision) { this.decision = decision; }
}
