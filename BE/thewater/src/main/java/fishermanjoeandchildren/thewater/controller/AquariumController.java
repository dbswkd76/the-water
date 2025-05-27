package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.ApiResponse;
import fishermanjoeandchildren.thewater.data.dto.AquariumDto;
import fishermanjoeandchildren.thewater.data.dto.AquariumRankingDto;
import fishermanjoeandchildren.thewater.db.entity.Aquarium;
import fishermanjoeandchildren.thewater.security.JwtUtil;
import fishermanjoeandchildren.thewater.service.AquariumService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequiredArgsConstructor
@RequestMapping("/api/aquarium")
public class AquariumController {

    private final AquariumService aquariumService;
    private final JwtUtil jwtUtil;

    @SecurityRequirement(name="BearerAuth")
    @GetMapping("/info/{aquarium_id}")
    public ApiResponse<?> getAquariumInfo(@PathVariable("aquarium_id") Long aquariumId, HttpServletRequest request){
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);
        ApiResponse<?> result = aquariumService.getAquarium(aquariumId, memberId);

        return result;
    }

    @SecurityRequirement(name="BearerAuth")
    @GetMapping("/info/me")
    public ApiResponse<?> getAquariumMyInfo(HttpServletRequest request){
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);
        ApiResponse<?> result = aquariumService.getMyAquarium(memberId);

        return result;
    }

    @PostMapping("/visit/{aquarium_id}")
    public ApiResponse<?> updateAquariumVisitors(@PathVariable("aquarium_id") Long aquariumId){
        ApiResponse<?> result = aquariumService.updateVisitorCount(aquariumId);

        return result;
    }

    @SecurityRequirement(name="BearerAuth")
    @PostMapping(value="/like/{aquarium_id}")
    public ApiResponse<?> likeAquarium(@PathVariable("aquarium_id") Long aquariumId, HttpServletRequest request){
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);

        ApiResponse<?> result = aquariumService.likeAquarium(aquariumId,memberId);

        return result;
    }

    @SecurityRequirement(name="BearerAuth")
    @DeleteMapping("/like/{aquarium_id}")
    public ApiResponse<?> unlikeAquarium(@PathVariable("aquarium_id") Long aquariumId, HttpServletRequest request){
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);

        ApiResponse<?> result = aquariumService.unlikeAquarium(aquariumId, memberId);

        return result;
    }

    @SecurityRequirement(name="BearerAuth")
    @PatchMapping("visible/{fish_id}")
    public ApiResponse<?> addAquariumFish(@PathVariable("fish_id") Long fishId, HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);

        ApiResponse<?> result = aquariumService.changeAquariumFishVisible(memberId, fishId);

        return result;
    }


    @GetMapping("ranking/top/{number}")
    public ApiResponse<List<AquariumRankingDto>> getAquariumRanking(@PathVariable("number") Integer number){
        ApiResponse<List<AquariumRankingDto>> result = aquariumService.getTopAquariums(number);

        return result;
    }

    @GetMapping("ranking/random/{number}")
    public ApiResponse<List<AquariumRankingDto>> getRandomAquarium(@PathVariable("number") Integer number){
        ApiResponse<List<AquariumRankingDto>> result = aquariumService.getRandomAquariums(number);

        return result;
    }

    @SecurityRequirement(name="BearerAuth")
    @PatchMapping("open")
    public ApiResponse<?> changeAquariumOpen(HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);

        ApiResponse<?> result = aquariumService.changeAquariumOpen(memberId);

        return result;
    }

}
