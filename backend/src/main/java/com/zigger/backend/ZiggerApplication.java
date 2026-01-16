package com.zigger.backend;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ZiggerApplication {

	public static void main(String[] args) {
		SpringApplication.run(ZiggerApplication.class, args);
	}
	@org.springframework.context.annotation.Bean
	public org.springframework.boot.CommandLineRunner run(org.springframework.jdbc.core.JdbcTemplate jdbcTemplate) {
		return args -> {
			try {
				jdbcTemplate.execute("ALTER TABLE profiles DROP CONSTRAINT profiles_kyc_status_check");
				System.out.println("✅ Constraint profiles_kyc_status_check dropped successfully.");
			} catch (Exception e) {
				System.out.println("⚠️ Constraint profiles_kyc_status_check drop skipped/failed: " + e.getMessage());
			}

			try {
				jdbcTemplate.execute("ALTER TABLE profiles DROP CONSTRAINT profiles_role_check");
				System.out.println("✅ Constraint profiles_role_check dropped successfully.");
			} catch (Exception e) {
				System.out.println("⚠️ Constraint profiles_role_check drop skipped/failed: " + e.getMessage());
			}

			try {
				jdbcTemplate.execute("ALTER TABLE profiles DROP CONSTRAINT profiles_id_fkey");
				System.out.println("✅ Constraint profiles_id_fkey dropped successfully.");
			} catch (Exception e) {
				System.out.println("⚠️ Constraint profiles_id_fkey drop skipped/failed: " + e.getMessage());
			}
		};
	}
}
