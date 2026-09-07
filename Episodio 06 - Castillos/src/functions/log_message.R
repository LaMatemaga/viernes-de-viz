#-----------------------------------------------------------------------------
# log_message.R
#-----------------------------------------------------------------------------
#   Simplify and improve the logging mechanism in your R script by creating a
#   function that handles logging across different types of system messages.
#-----------------------------------------------------------------------------

log_message <- function(message, logs, type="info"){
    # Generate a timestamped message
    timestamped_message <- paste0(Sys.time(), " - ", toupper(type), ": ", message)

    # Append the message to the appropriate log list
    logs <- c(logs, timestamped_message)
    
    # Handle messaging based on type using
    switch(type,
           info = {cat(timestamped_message, "\n")},
           warning = {warning(timestamped_message)},
           error = {stop(timestamped_message)},
           message = {message(timestamped_message)},
           cat = {cat(timestamped_message, "\n")},
           {stop("Invalid log type. Use 'info', 'warning', or 'error'.")}
    )

    # Return the updated logs
    return(logs)
}

logs <- c()  # Initialize an empty log list

#-----------------------------------------------------------------------------
# End of log_message.R
#-----------------------------------------------------------------------------

# Example usage:
# logs <- log_message("This is an informational message.", logs, type="info")
# logs <- log_message("This is a warning message.", logs, type="warning")
# logs <- log_message("This is an error message.", logs, type="error")
# logs <- log_message("This is a custom message.", logs, type="message")
# To view the logs
# print(logs)