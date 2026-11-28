package com.unimanager.backend.config;

import com.unimanager.backend.model.AcademicRecord;
import com.unimanager.backend.model.Student;
import com.unimanager.backend.model.StudentDocument;
import com.unimanager.backend.model.StudentStatus;
import com.unimanager.backend.repository.StudentMongoRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;

@Configuration
public class DataInitializer {

    @Bean
    CommandLineRunner initDatabase(StudentMongoRepository repository) {
        return args -> {
            if (repository.count() > 0) {
                return; // Déjà peuplée dans MongoDB
            }

            Student s1 = new Student();
            s1.setId("std_01");
            s1.setMatricule("ETU-2026-001");
            s1.setNom("Benali");
            s1.setPrenom("Yasmine");
            s1.setDateNaissance(LocalDate.of(2003, 4, 15));
            s1.setEmail("yasmine.benali@unimanager.edu");
            s1.setTelephone("+212 6 12 34 56 78");
            s1.setFiliere("Génie Logiciel");
            s1.setNiveau("Licence 3 (L3)");
            s1.setClasse("L3-GL-A");
            s1.setStatut(StudentStatus.actif);
            s1.setGenre("F");
            s1.setAdresse("Résidence Universitaire Al-Amal, Bâtiment C");
            s1.setDocuments(List.of(
                    new StudentDocument("doc_1", "Carte Nationale d'Identité (CNIE)", "Identité", "cnie_yasmine_benali.pdf", Instant.now(), true),
                    new StudentDocument("doc_2", "Attestation du Baccalauréat Scientifique", "Baccalauréat", "bac_scientifique_2022.pdf", Instant.now(), true),
                    new StudentDocument("doc_3", "Certificat d'Aptitude Médicale", "Médical", "certificat_medical_2025.pdf", Instant.now(), true)
            ));
            s1.setHistorique(List.of(
                    new AcademicRecord("2023-2024", "Licence 1", "L1-INFO-C", 15.65, "Bien", "Admis"),
                    new AcademicRecord("2024-2025", "Licence 2", "L2-INFO-A", 16.20, "Très Bien", "Admis (Major de promotion)")
            ));

            Student s2 = new Student();
            s2.setId("std_02");
            s2.setMatricule("ETU-2026-002");
            s2.setNom("El Amrani");
            s2.setPrenom("Karim");
            s2.setDateNaissance(LocalDate.of(2002, 11, 20));
            s2.setEmail("karim.elamrani@unimanager.edu");
            s2.setTelephone("+212 6 98 76 54 32");
            s2.setFiliere("Intelligence Artificielle & Data");
            s2.setNiveau("Master 1 (M1)");
            s2.setClasse("M1-DS");
            s2.setStatut(StudentStatus.actif);
            s2.setGenre("M");
            s2.setAdresse("12 Avenue des Nations Unies, Quartier Agdal");
            s2.setDocuments(List.of(
                    new StudentDocument("doc_4", "Licence Fondamentale en Informatique", "Attestation", "diplome_licence_info.pdf", Instant.now(), true)
            ));
            s2.setHistorique(List.of(
                    new AcademicRecord("2024-2025", "Licence 3", "L3-INFO-B", 14.90, "Bien", "Admis en Master")
            ));

            Student s3 = new Student();
            s3.setId("std_03");
            s3.setMatricule("ETU-2026-003");
            s3.setNom("Tazi");
            s3.setPrenom("Salma");
            s3.setDateNaissance(LocalDate.of(2004, 2, 8));
            s3.setEmail("salma.tazi@unimanager.edu");
            s3.setTelephone("+212 6 55 44 33 22");
            s3.setFiliere("Systèmes & Réseaux Informatiques");
            s3.setNiveau("Licence 2 (L2)");
            s3.setClasse("L2-SRI");
            s3.setStatut(StudentStatus.actif);
            s3.setGenre("F");
            s3.setAdresse("45 Rue Ibn Battouta");

            Student s4 = new Student();
            s4.setId("std_04");
            s4.setMatricule("ETU-2026-004");
            s4.setNom("Mansouri");
            s4.setPrenom("Omar");
            s4.setDateNaissance(LocalDate.of(2001, 7, 30));
            s4.setEmail("omar.mansouri@unimanager.edu");
            s4.setTelephone("+212 6 22 11 00 99");
            s4.setFiliere("Cybersécurité");
            s4.setNiveau("Master 2 (M2)");
            s4.setClasse("M2-CYBER");
            s4.setStatut(StudentStatus.diplome);
            s4.setGenre("M");
            s4.setAdresse("88 Boulevard Hassan II");
            s4.setHistorique(List.of(
                    new AcademicRecord("2024-2025", "Master 2", "M2-CYBER", 17.10, "Très Bien", "Diplômé avec Félicitations du Jury")
            ));

            Student s5 = new Student();
            s5.setId("std_05");
            s5.setMatricule("ETU-2026-005");
            s5.setNom("Chraibi");
            s5.setPrenom("Mehdi");
            s5.setDateNaissance(LocalDate.of(2003, 10, 12));
            s5.setEmail("mehdi.chraibi@unimanager.edu");
            s5.setTelephone("+212 6 77 88 99 00");
            s5.setFiliere("Génie Logiciel");
            s5.setNiveau("Licence 3 (L3)");
            s5.setClasse("L3-GL-B");
            s5.setStatut(StudentStatus.suspendu);
            s5.setGenre("M");
            s5.setAdresse("Résidence Universitaire Al-Amal, Bâtiment B");

            Student s6 = new Student();
            s6.setId("std_06");
            s6.setMatricule("ETU-2026-006");
            s6.setNom("Berrada");
            s6.setPrenom("Amina");
            s6.setDateNaissance(LocalDate.of(2003, 5, 25));
            s6.setEmail("amina.berrada@unimanager.edu");
            s6.setTelephone("+212 6 43 21 87 65");
            s6.setFiliere("Management des SI");
            s6.setNiveau("Master 1 (M1)");
            s6.setClasse("M1-MSI");
            s6.setStatut(StudentStatus.actif);
            s6.setGenre("F");
            s6.setAdresse("33 Avenue Mohammed VI");

            repository.saveAll(List.of(s1, s2, s3, s4, s5, s6));
        };
    }
}
