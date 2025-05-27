package com.water.water.db.repository;

import com.water.water.db.entity.FishCard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface FishCardRepository extends JpaRepository<FishCard, Long> {
}
