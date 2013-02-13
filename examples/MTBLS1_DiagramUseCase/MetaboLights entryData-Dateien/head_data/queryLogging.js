/*
 * Create or update a EBeye's user id to trace the queries to the EB-eye.
 * this piece of information is strictly for internal and anonymized statistics and won't be shared.
 */

function createOrUpdateEBeyeUSerIdCookie() {
	loggingEnabled = true;
	if (!loggingEnabled) {
		return;
	}
	var userIdCookieName = "EBeyeUserId";
	var userIdCookieMaxAge = 365; // days.

	var userIdCookieValue = jaaulde.utils.cookies.get(userIdCookieName);
	if (userIdCookieValue == null) {
		userIdCookieValue = randomnumber=Math.floor(Math.random()*1001) + "_" + new Date().getTime();
	}
	var expireDate = new Date();
	expireDate.setDate(expireDate.getDate() + userIdCookieMaxAge);
	jaaulde.utils.cookies.set(userIdCookieName, userIdCookieValue, { expiresAt: expireDate });
}
