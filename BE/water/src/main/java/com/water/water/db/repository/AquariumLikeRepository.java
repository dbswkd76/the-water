package com.water.water.db.repository;

import com.water.water.db.entity.AquariumLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AquariumLikeRepository extends JpaRepository<AquariumLike, Long> {
}
