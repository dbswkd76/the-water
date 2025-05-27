package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.data.dto.ApiResponse;
import fishermanjoeandchildren.thewater.data.dto.GuestBookRequestDto;
import fishermanjoeandchildren.thewater.security.JwtUtil;
import fishermanjoeandchildren.thewater.service.GuestBookService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/guest-book")
public class GuestBookController {

    private final GuestBookService guestBookService;
    private final JwtUtil jwtUtil;

    @GetMapping("/read/{aquarium-id}")
    public ApiResponse<?> getGuestBookComments(@PathVariable("aquarium-id") Long aquariumId, HttpServletRequest request){
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);

        return guestBookService.getComments(aquariumId,memberId);
    }

    @GetMapping("/read/me")
    public ApiResponse<?> getGuestBookComments(HttpServletRequest request){
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);

        return guestBookService.getMyGeustBookComments(memberId);
    }

    @PostMapping("/write/{aquarium-id}")
    public ApiResponse<?> writeGuestBookComment(@RequestBody GuestBookRequestDto guestBookDto, @PathVariable("aquarium-id") Long aquariumId, HttpServletRequest request){
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);

        return guestBookService.writeComment(guestBookDto,aquariumId, memberId);
    }

    @PutMapping("/edit/{guest-book-id}")
    public ApiResponse<?> editGuestBookComment(@RequestBody GuestBookRequestDto guestBookDto, @PathVariable("guest-book-id") Long guestBookId, HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);
        return guestBookService.editComment(guestBookId, memberId, guestBookDto);
    }

    @DeleteMapping("/remove/{guest-book-id}")
    public ApiResponse<?> deleteGuestBookComment(@PathVariable("guest-book-id") Long guestBookId, HttpServletRequest request) {
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);
        return guestBookService.deleteComment(guestBookId, memberId);
    }


}
