export const getToken = (header: string): string => {
    // Perform authorization if needed
    const token = header;
    if (!token) {
        console.log('Invalid authorization token');
        throw new Error('Unauthorized');
    }

    const match = token.match(/^Bearer (.*)$/);
    if (!match || match.length < 2) {
        console.log(
            `Invalid Authorization token - ${token} does not match 'Bearer .*'`
        );
        throw new Error('Unauthorized token wrong format');
    }
    return match[1];
};