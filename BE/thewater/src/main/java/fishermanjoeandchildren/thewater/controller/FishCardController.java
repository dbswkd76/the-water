package fishermanjoeandchildren.thewater.controller;

import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import fishermanjoeandchildren.thewater.data.dto.ApiResponse;
import fishermanjoeandchildren.thewater.data.dto.FishCardDto;
import fishermanjoeandchildren.thewater.security.JwtUtil;
import fishermanjoeandchildren.thewater.service.FishCardService;
import io.swagger.v3.oas.annotations.Parameter;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@RestController
@RequestMapping("/api/collection")
@RequiredArgsConstructor
public class FishCardController {

    private final FishCardService fishCardService;
    private final JwtUtil jwtUtil;

    @Value("${file.upload-dir}")
    private String uploadDir;

    @GetMapping("/myfish/all")
    public ApiResponse<?>getMyFishAll(HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);

        ApiResponse<?> result =fishCardService.getAllFishCards(memberId);
        return result;
    }


    @PostMapping(value = "/myfish/add", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<?> addFishCard(
            @RequestPart("fishCard") @Parameter(description = "fishCard JSON") FishCardDto fishCardDto,
            @RequestPart("image") @Parameter(description = "이미지 파일") MultipartFile image,
            HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);

        ApiResponse<?> result = fishCardService.addFishCard(fishCardDto, memberId, image);
        return result;
    }


    @DeleteMapping("/myfish/delete/{fishcard_id}")
    public ApiResponse<?> deleteFishCard(@PathVariable("fishcard_id") Long fishCardId, HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);


        ApiResponse<?> result = fishCardService.deleteFishCard(fishCardId, memberId);
        return result;
    }

    @GetMapping("/myfish/image/{filename}")
    public ResponseEntity<Resource> getImage(@PathVariable String filename) throws IOException {
        Path imagePath = Paths.get(uploadDir).resolve(filename).normalize();
        Resource resource = new UrlResource(imagePath.toUri());

        if (resource.exists() && resource.isReadable()) {
            String contentType = Files.probeContentType(imagePath);
            System.out.println("CONTENT TYPE");
            if (contentType == null) {
                contentType = "application/octet-stream";
            }

            return ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(contentType))
                    .body(resource);
        } else {
            return ResponseEntity.notFound().build();
        }
    }



}
