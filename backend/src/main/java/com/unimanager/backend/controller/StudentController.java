package com.unimanager.backend.controller;

import com.unimanager.backend.model.Student;
import com.unimanager.backend.model.StudentDocument;
import com.unimanager.backend.model.StudentStatus;
import com.unimanager.backend.service.StudentService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/students")
@CrossOrigin(origins = "*")
public class StudentController {

    private final StudentService studentService;

    public StudentController(StudentService studentService) {
        this.studentService = studentService;
    }

    @GetMapping
    public ResponseEntity<List<Student>> getAllStudents(
            @RequestParam(required = false) String query,
            @RequestParam(required = false) StudentStatus status,
            @RequestParam(required = false) String filiere,
            @RequestParam(required = false, defaultValue = "name_asc") String sortBy
    ) {
        return ResponseEntity.ok(studentService.getAllStudents(query, status, filiere, sortBy));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Student> getStudentById(@PathVariable String id) {
        return ResponseEntity.ok(studentService.getStudentById(id));
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Long>> getStats() {
        return ResponseEntity.ok(studentService.getStats());
    }

    @PostMapping
    public ResponseEntity<Student> createStudent(@Valid @RequestBody Student student) {
        return ResponseEntity.status(HttpStatus.CREATED).body(studentService.createStudent(student));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Student> updateStudent(@PathVariable String id, @Valid @RequestBody Student student) {
        return ResponseEntity.ok(studentService.updateStudent(id, student));
    }

    @PatchMapping("/{id}/status")
    public ResponseEntity<Student> updateStatus(@PathVariable String id, @RequestBody Map<String, String> payload) {
        String statusValue = payload.get("statut");
        if (statusValue == null) {
            throw new IllegalArgumentException("Le champ 'statut' est requis.");
        }
        StudentStatus newStatus = StudentStatus.valueOf(statusValue);
        return ResponseEntity.ok(studentService.updateStatus(id, newStatus));
    }

    @PostMapping("/{id}/documents")
    public ResponseEntity<Student> addDocument(@PathVariable String id, @RequestBody StudentDocument document) {
        return ResponseEntity.ok(studentService.addDocument(id, document));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteStudent(@PathVariable String id) {
        studentService.deleteStudent(id);
        return ResponseEntity.noContent().build();
    }
}
