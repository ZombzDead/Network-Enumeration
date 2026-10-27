/**
 * Get the IP address for a given hostname.
 * If the input is already an IP address, return it unchanged.
 * If a domain resolves to another domain (CNAME), continue resolving until an IP is found.
 *
 * @param {string} host - The hostname or IP address.
 * @return {string} The IP address or an error message if not resolvable.
 * @customfunction
 */
function RESOLVEIP(host) {
  if (host === '' || host === null) return '';

  // Regular expression to check if the input is already an IP address
  var ipRegex = /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/;

  // If the host is already a valid IP address, return it
  if (ipRegex.test(host)) {
    return host;
  }

  // Loop to continue resolving if the result is a domain name (CNAME)
  var resolvedHost = host;
  for (var i = 0; i < 5; i++) {  // Limit the number of iterations to prevent infinite loops
    try {
      var response = UrlFetchApp.fetch('https://dns.google/resolve?name=' + resolvedHost);
      var data = JSON.parse(response.getContentText());

      // Check if the response contains an IP address
      if (data.Answer && data.Answer.length > 0) {
        var answer = data.Answer[0].data;
        
        // If the answer is a valid IP, return it
        if (ipRegex.test(answer)) {
          return answer;
        }
        
        // Otherwise, assume it's another domain (CNAME), continue resolving
        resolvedHost = answer;
      } else {
        return 'Error resolving IP';
      }
    } catch (error) {
      return 'Error resolving IP';
    }
  }

  return 'Unable to resolve to an IP after several attempts';
}
