package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.ApiResponse;
import fishermanjoeandchildren.thewater.data.dto.FishingPointDto;
import fishermanjoeandchildren.thewater.data.dto.MemberFishingPointDto;
import fishermanjoeandchildren.thewater.data.dto.MemberFishingPointRequestDto;
import fishermanjoeandchildren.thewater.db.entity.MemberFishingPoint;
import fishermanjoeandchildren.thewater.security.JwtUtil;
import fishermanjoeandchildren.thewater.service.FishingPointService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/fishing-points")
@RequiredArgsConstructor
public class FishingPointController {

    private final FishingPointService fishingPointService;
    private final JwtUtil jwtUtil;

    @SecurityRequirement(name="BearerAuth")
    @GetMapping("/all")
    public ApiResponse<List<FishingPointDto>> getAllFishingPoints() {
        List<FishingPointDto> fishingPoints = fishingPointService.getAllFishingPoints();

        return ApiResponse.<List<FishingPointDto>>builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(fishingPoints)
                .build();
    }

    @SecurityRequirement(name="BearerAuth")
    @GetMapping("/me")
    public ApiResponse<List<MemberFishingPointDto>> getMyFishingPoints(HttpServletRequest request) {
        // JWT 토큰에서 회원 ID 추출
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);

        // 회원 낚시 포인트 가져오기
        List<MemberFishingPointDto> myFishingPoints = fishingPointService.getMemberFishingPoints(memberId);

        return ApiResponse.<List<MemberFishingPointDto>>builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(myFishingPoints)
                .build();
    }

    @SecurityRequirement(name="BearerAuth")
    @PostMapping("/add")
    public ApiResponse<?> addFishingPoint(@RequestParam (required = false) String pointName,
                                          @RequestParam Double latitude,
                                          @RequestParam Double longitude,
                                          @RequestParam(required = false) String comment,
                                          HttpServletRequest request) {
        try {
            // JWT 토큰에서 회원 ID 추출
            String token = jwtUtil.resolveToken(request);
            Long memberId = jwtUtil.extractUserId(token);

            // 낚시 포인트 추가 (주소는 서비스에서 자동으로 파싱)
            MemberFishingPoint addedPoint = fishingPointService.addMemberFishingPoint(memberId, pointName, latitude, longitude, comment);

            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data(addedPoint)
                    .build();
        } catch (Exception e) {
            return ApiResponse.builder()
                    .status(ResponseStatus.BAD_REQUEST)
                    .message(ResponseMessage.BAD_REQUEST)
                    .data("낚시 포인트 추가 실패: " + e.getMessage())
                    .build();
        }
    }

    @SecurityRequirement(name="BearerAuth")
    @PatchMapping("/edit/{pointId}")
    public ApiResponse<?> patchFishingPoint(@PathVariable Long pointId,
                                            @RequestParam(required = false) String pointName,
                                            @RequestParam(required = false) String comment,
                                            HttpServletRequest request) {
        try {
            // JWT 토큰에서 회원 ID 추출
            String token = jwtUtil.resolveToken(request);
            Long memberId = jwtUtil.extractUserId(token);

            // 낚시 포인트 부분 수정
            MemberFishingPoint updatedPoint = fishingPointService.patchMemberFishingPoint(pointId, memberId, pointName, comment);

            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data(updatedPoint)
                    .build();
        } catch (IllegalArgumentException e) {
            return ApiResponse.builder()
                    .status(ResponseStatus.AUTHROIZATION_FAILED)
                    .message(ResponseMessage.AUTHROIZATION_FAILED)
                    .data(e.getMessage())
                    .build();
        } catch (Exception e) {
            return ApiResponse.builder()
                    .status(ResponseStatus.BAD_REQUEST)
                    .message(ResponseMessage.BAD_REQUEST)
                    .data("낚시 포인트 수정 실패: " + e.getMessage())
                    .build();
        }
    }

    @SecurityRequirement(name="BearerAuth")
    @DeleteMapping("/delete/{pointId}")
    public ApiResponse<?> deleteFishingPoint(@PathVariable Long pointId,
                                             HttpServletRequest request) {
        try {
            // JWT 토큰에서 회원 ID 추출
            String token = jwtUtil.resolveToken(request);
            Long memberId = jwtUtil.extractUserId(token);

            // 낚시 포인트 삭제
            fishingPointService.deleteMemberFishingPoint(pointId, memberId);

            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data("낚시 포인트가 성공적으로 삭제되었습니다.")
                    .build();
        } catch (IllegalArgumentException e) {
            return ApiResponse.builder()
                    .status(ResponseStatus.AUTHROIZATION_FAILED)
                    .message(ResponseMessage.AUTHROIZATION_FAILED)
                    .data(e.getMessage())
                    .build();
        } catch (Exception e) {
            return ApiResponse.builder()
                    .status(ResponseStatus.BAD_REQUEST)
                    .message(ResponseMessage.BAD_REQUEST)
                    .data("낚시 포인트 삭제 실패: " + e.getMessage())
                    .build();
        }
    }
}