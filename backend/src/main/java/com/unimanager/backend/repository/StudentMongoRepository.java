package com.unimanager.backend.repository;

import com.unimanager.backend.model.Student;
import com.unimanager.backend.model.StudentStatus;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentMongoRepository extends MongoRepository<Student, String> {
    Optional<Student> findByMatriculeIgnoreCase(String matricule);
    boolean existsByMatriculeIgnoreCase(String matricule);
    boolean existsByMatriculeIgnoreCaseAndIdNot(String matricule, String id);

    boolean existsByEmailIgnoreCaseAndStatut(String email, StudentStatus statut);
    boolean existsByEmailIgnoreCaseAndStatutAndIdNot(String email, StudentStatus statut, String id);

    List<Student> findByStatut(StudentStatus statut);
    List<Student> findByFiliere(String filiere);
    List<Student> findByClasse(String classe);

    long countByStatut(StudentStatus statut);
}
