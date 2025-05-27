package fishermanjoeandchildren.thewater.data;

public interface ResponseMessage {

    // HTTP Status 200
    String SUCCESS = "Success.";
    // HTTP status
    String CREATE = "Create";

    // HTTP Status 400
    String VALIDATION_FAILED = "Validation failed";
    String BAD_REQUEST = "Bad request";
    String NOT_FOUND = "Not found";
    String NOT_FOUND_PAGE = "Not found page";


    // HTTP Status 401
    String SIGN_IN_FAIL = "Login information mismatch";
    String AUTHROIZATION_FAILED = "Authorization failed";

    // HTTP Status 403
    String NO_PERMISSION = "Do not have permission.";

    // HTTP Status 409
    String CONFLICT = "Conflict occur";

    // HTTP Status 500
    String DATABASE_ERROR = "Database error";

    String SERVER_ERROR = "Server error";


}
