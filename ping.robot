*** Settings ***
Library   OperatingSystem
Library   Process
Library   String
Library   BuiltIn

*** Variables ***
${WEBPAGES_FILE}  webpages.txt
${PING_COMMAND}   ping
${OUTPUT_FILE}    ping_results.txt

*** Test Cases ***
Read and Ping Webpages
  [Documentation]  Read a list of webpages, ping them, and analyze the response times.

  # Read the content of webpages.txt
  ${webpages_content}=  Get File  ${WEBPAGES_FILE}
  Log To Console  Content of webpages.txt:\n${webpages_content}

  # Split the content into a list using the newline character
  ${webpages}=  Split String  ${webpages_content}  \n
  Log To Console  Split webpages:\n@{webpages}

  # Iterate through each webpage and run the ping test
  FOR  ${webpage}  IN  @{webpages}
    Log To Console  Processing webpage: ${webpage}
    Run Ping Test for Webpage  ${webpage}
  END

*** Keywords ***
Run Ping Test for Webpage
  [Arguments]  ${webpage}
  
  # Execute the ping command and save the output to output.txt and stderr.txt files
  Log To Console  Running ping for webpage: ${webpage}
  ${result}=  Run Process  ${PING_COMMAND}  ${webpage}  stdout=output.txt  stderr=stderr.txt  shell=True

  # Print the result of the ping command execution
  Log To Console  Ping command finished for ${webpage}, output saved to output.txt and stderr.txt

  # Parse the ping result
  Parse Ping Results  ${webpage}

Parse Ping Results
  [Arguments]  ${webpage}

  # Read the ping result from the output.txt file
  ${ping_output}=  Get File  output.txt
  Log To Console  Ping Output for ${webpage}:\n${ping_output}

  # Extract the IP address (matching the IP in square brackets)
  ${ip_address}=  Get Regexp Matches  ${ping_output}  \\[([\\d\\.]+)\\]
  Log To Console  IP Address for ${webpage}: ${ip_address}

  # Extract the time values from each ping
  ${ping_times}=  Get Regexp Matches  ${ping_output}  time=([0-9]+)ms
  Log To Console  Ping Times for ${webpage}: ${ping_times}

  # Remove "time=" and "ms" from the string, keep the numeric part, and convert it to integers
  ${ping_times_numeric}=  Evaluate  [int(s.replace('time=', '').replace('ms', '')) for s in ${ping_times}]
  Log To Console  Numeric Ping Times for ${webpage}: ${ping_times_numeric}

  # Calculate the average ping time
  ${average_ping_time}=  Evaluate  sum(${ping_times_numeric}) / len(${ping_times_numeric})
  Log To Console  Average Ping Time for ${webpage}: ${average_ping_time} ms

  # Write the IP address and average ping time to the file
  Write Ping Result To File  ${webpage}  ${ip_address[0]}  ${average_ping_time}

*** Keywords ***
Write Ping Result To File
  [Arguments]  ${webpage}  ${ip}  ${avg_time}
  # Append the result to the file
  Append To File  ${OUTPUT_FILE}  Webpage: ${webpage}, IP: ${ip}, Avg Ping: ${avg_time} ms\n
  Log To Console  Written to file: Webpage: ${webpage}, IP: ${ip}, Avg Ping: ${avg_time} ms


#Ilyas Oubousken