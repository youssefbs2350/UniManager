package com.unimanager.backend.model;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Document(collection = "students")
public class Student {

    @Id
    private String id;

    @NotBlank(message = "Le matricule est obligatoire")
    @Indexed(unique = true)
    private String matricule;

    @NotBlank(message = "Le nom est obligatoire")
    private String nom;

    @NotBlank(message = "Le prénom est obligatoire")
    private String prenom;

    @NotNull(message = "La date de naissance est obligatoire")
    private LocalDate dateNaissance;

    @NotBlank(message = "L'email est obligatoire")
    @Email(message = "Format d'email invalide")
    private String email;

    @NotBlank(message = "Le téléphone est obligatoire")
    private String telephone;

    @NotBlank(message = "La filière est obligatoire")
    private String filiere;

    @NotBlank(message = "Le niveau est obligatoire")
    private String niveau;

    @NotBlank(message = "La classe est obligatoire")
    private String classe;

    @NotNull(message = "Le statut est obligatoire")
    private StudentStatus statut = StudentStatus.actif;

    private String avatarUrl;
    private String genre = "M";
    private String adresse = "Campus Universitaire";

    private List<StudentDocument> documents = new ArrayList<>();
    private List<AcademicRecord> historique = new ArrayList<>();
    private Instant dateCreation = Instant.now();

    public Student() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getMatricule() { return matricule; }
    public void setMatricule(String matricule) { this.matricule = matricule; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }

    public LocalDate getDateNaissance() { return dateNaissance; }
    public void setDateNaissance(LocalDate dateNaissance) { this.dateNaissance = dateNaissance; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }

    public String getFiliere() { return filiere; }
    public void setFiliere(String filiere) { this.filiere = filiere; }

    public String getNiveau() { return niveau; }
    public void setNiveau(String niveau) { this.niveau = niveau; }

    public String getClasse() { return classe; }
    public void setClasse(String classe) { this.classe = classe; }

    public StudentStatus getStatut() { return statut; }
    public void setStatut(StudentStatus statut) { this.statut = statut; }

    public String getAvatarUrl() { return avatarUrl; }
    public void setAvatarUrl(String avatarUrl) { this.avatarUrl = avatarUrl; }

    public String getGenre() { return genre; }
    public void setGenre(String genre) { this.genre = genre; }

    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }

    public List<StudentDocument> getDocuments() { return documents; }
    public void setDocuments(List<StudentDocument> documents) { this.documents = documents != null ? documents : new ArrayList<>(); }

    public List<AcademicRecord> getHistorique() { return historique; }
    public void setHistorique(List<AcademicRecord> historique) { this.historique = historique != null ? historique : new ArrayList<>(); }

    public Instant getDateCreation() { return dateCreation; }
    public void setDateCreation(Instant dateCreation) { this.dateCreation = dateCreation; }
}
