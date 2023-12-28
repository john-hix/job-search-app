import axios from 'axios';

let client = null;

export const createClient = ({ token }) => {
    const config = {
        baseURL: import.meta.env.PROD
            ? import.meta.env.VITE_API_BASE_URL_PROD
            : import.meta.env.VITE_API_BASE_URL_DEV,
        timeout: 1000,
        headers: {'X-Custom-Header': 'foobar'}
    };
    if (token) {
        config.headers = {
            'Authorization': `Bearer ${token}`,
            ...config.headers
        }
    }
    client = axios.create(config);
    return client;
}

const apiGetter = () => {
    if (client) {
        return client;
    } else {
        return createClient({});
    }
}

export default apiGetter;
