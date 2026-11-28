package com.unimanager.backend.service;

import com.unimanager.backend.model.Student;
import com.unimanager.backend.model.StudentDocument;
import com.unimanager.backend.model.StudentStatus;
import com.unimanager.backend.repository.StudentMongoRepository;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class StudentService {

    private final StudentMongoRepository repository;

    public StudentService(StudentMongoRepository repository) {
        this.repository = repository;
    }

    public List<Student> getAllStudents(String query, StudentStatus status, String filiere, String sortBy) {
        List<Student> students = repository.findAll();

        if (query != null && !query.isBlank()) {
            String q = query.trim().toLowerCase();
            students = students.stream().filter(s ->
                    (s.getNom() != null && s.getNom().toLowerCase().contains(q)) ||
                    (s.getPrenom() != null && s.getPrenom().toLowerCase().contains(q)) ||
                    (s.getMatricule() != null && s.getMatricule().toLowerCase().contains(q)) ||
                    (s.getEmail() != null && s.getEmail().toLowerCase().contains(q)) ||
                    (s.getClasse() != null && s.getClasse().toLowerCase().contains(q))
            ).toList();
        }

        if (status != null) {
            students = students.stream().filter(s -> s.getStatut() == status).toList();
        }

        if (filiere != null && !filiere.isBlank() && !"Toutes".equalsIgnoreCase(filiere)) {
            students = students.stream().filter(s -> filiere.equalsIgnoreCase(s.getFiliere())).toList();
        }

        Comparator<Student> comparator = switch (sortBy != null ? sortBy : "name_asc") {
            case "name_desc" -> Comparator.comparing(Student::getNom, String.CASE_INSENSITIVE_ORDER).reversed();
            case "matricule" -> Comparator.comparing(Student::getMatricule, String.CASE_INSENSITIVE_ORDER);
            case "date" -> Comparator.comparing(Student::getDateCreation, Comparator.nullsLast(Comparator.naturalOrder())).reversed();
            default -> Comparator.comparing(Student::getNom, String.CASE_INSENSITIVE_ORDER);
        };

        return students.stream().sorted(comparator).toList();
    }

    public Student getStudentById(String id) {
        return repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Étudiant introuvable avec l'id : " + id));
    }

    public Student createStudent(Student student) {
        student.setMatricule(student.getMatricule().trim().toUpperCase());
        student.setEmail(student.getEmail().trim().toLowerCase());

        if (repository.existsByMatriculeIgnoreCase(student.getMatricule())) {
            throw new IllegalArgumentException("Le matricule " + student.getMatricule() + " est déjà attribué à un autre étudiant.");
        }

        if (student.getStatut() == StudentStatus.actif &&
            repository.existsByEmailIgnoreCaseAndStatut(student.getEmail(), StudentStatus.actif)) {
            throw new IllegalArgumentException("L'adresse email " + student.getEmail() + " est déjà associée à un autre compte actif.");
        }

        if (student.getClasse() == null || student.getClasse().isBlank()) {
            throw new IllegalArgumentException("Un étudiant doit obligatoirement être rattaché à une classe.");
        }

        if (student.getDateCreation() == null) {
            student.setDateCreation(Instant.now());
        }

        return repository.save(student);
    }

    public Student updateStudent(String id, Student updated) {
        Student existing = getStudentById(id);

        String cleanMatricule = updated.getMatricule().trim().toUpperCase();
        String cleanEmail = updated.getEmail().trim().toLowerCase();

        if (repository.existsByMatriculeIgnoreCaseAndIdNot(cleanMatricule, id)) {
            throw new IllegalArgumentException("Le matricule " + cleanMatricule + " existe déjà.");
        }

        if (updated.getStatut() == StudentStatus.actif &&
            repository.existsByEmailIgnoreCaseAndStatutAndIdNot(cleanEmail, StudentStatus.actif, id)) {
            throw new IllegalArgumentException("Cette adresse email est déjà utilisée par un compte actif.");
        }

        existing.setMatricule(cleanMatricule);
        existing.setNom(updated.getNom().trim());
        existing.setPrenom(updated.getPrenom().trim());
        existing.setDateNaissance(updated.getDateNaissance());
        existing.setEmail(cleanEmail);
        existing.setTelephone(updated.getTelephone().trim());
        existing.setFiliere(updated.getFiliere());
        existing.setNiveau(updated.getNiveau());
        existing.setClasse(updated.getClasse());
        existing.setStatut(updated.getStatut());
        existing.setGenre(updated.getGenre());
        existing.setAdresse(updated.getAdresse());
        if (updated.getDocuments() != null) {
            existing.setDocuments(updated.getDocuments());
        }
        if (updated.getHistorique() != null) {
            existing.setHistorique(updated.getHistorique());
        }

        return repository.save(existing);
    }

    public Student updateStatus(String id, StudentStatus newStatus) {
        Student existing = getStudentById(id);

        if (newStatus == StudentStatus.actif &&
            repository.existsByEmailIgnoreCaseAndStatutAndIdNot(existing.getEmail(), StudentStatus.actif, id)) {
            throw new IllegalArgumentException("Impossible de réactiver : email déjà lié à un autre compte actif.");
        }

        existing.setStatut(newStatus);
        return repository.save(existing);
    }

    public Student addDocument(String id, StudentDocument doc) {
        Student existing = getStudentById(id);
        if (doc.getId() == null || doc.getId().isBlank()) {
            doc.setId("doc_" + UUID.randomUUID().toString().substring(0, 8));
        }
        if (doc.getUploadDate() == null) {
            doc.setUploadDate(Instant.now());
        }
        existing.getDocuments().add(doc);
        return repository.save(existing);
    }

    public void deleteStudent(String id) {
        if (!repository.existsById(id)) {
            throw new IllegalArgumentException("Étudiant introuvable.");
        }
        repository.deleteById(id);
    }

    public Map<String, Long> getStats() {
        return Map.of(
                "total", repository.count(),
                "actif", repository.countByStatut(StudentStatus.actif),
                "suspendu", repository.countByStatut(StudentStatus.suspendu),
                "diplome", repository.countByStatut(StudentStatus.diplome)
        );
    }
}
