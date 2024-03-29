import * as React from 'react';
import Avatar from '@mui/material/Avatar';
import Button from '@mui/material/Button';
import CssBaseline from '@mui/material/CssBaseline';
import TextField from '@mui/material/TextField';
import Stack from '@mui/material/Stack';
import Paper from '@mui/material/Paper';
import Box from '@mui/material/Box';
import Grid from '@mui/material/Grid';
import LockOutlinedIcon from '@mui/icons-material/LockOutlined';
import Typography from '@mui/material/Typography';
import CircularProgress from '@mui/material/CircularProgress';
import Alert from '@mui/material/Alert';
import {  ThemeProvider } from '@mui/material/styles';
import Copyright from '../components/Copyright';
import theme from '../theme';
import {createClient} from '../api';
import { useState } from 'react';

export default function SignInSide() {

  const unauthenticatedApi = createClient({});

  const [isLoadingAuthReq, setIsLoadingAuthReq] = useState(false);
  const [authReqHadError, setAuthReqHadError] = useState(false);
  const [authReqErrorMsg, setAuthReqErrorMsg] = useState("");

  const handleSubmit = (event) => {
    event.preventDefault();
    setIsLoadingAuthReq(true);
    const data = new FormData(event.currentTarget);
    // DEBUG
    console.log({
      email: data.get('email'),
      password: data.get('password'),
    });
    // Call login API
    unauthenticatedApi.post('/auth', {
      username: data.get('email'),
      password: data.get('password')
    })
    .then((value) => {
      console.log(value); // DEBUG
      setIsLoadingAuthReq(false);
      
      // TODO: Set authenticated API client state globally

      setAuthReqHadError(false);
      setAuthReqErrorMsg('');
    })
    .catch((error) => {
      console.error(error); // DEBUG
      setIsLoadingAuthReq(false);
      
      if (error.response.status == 401) {
        setAuthReqErrorMsg('Username or password was incorrect.');
      }
      
      setAuthReqHadError(true);
    });

    // createClient({ token: '123'});
    console.log('Logged in.');
    // Router redirect
  };

  return (
    <ThemeProvider theme={theme}>
      <Grid container component="main" sx={{ height: '100vh' }}>
        <CssBaseline />
        <Grid
          item
          xs={false}
          sm={4}
          md={7}
          sx={{
            backgroundImage: 'url(https://source.unsplash.com/random?wallpapers)',
            backgroundRepeat: 'no-repeat',
            backgroundColor: (t) =>
              t.palette.mode === 'light' ? t.palette.grey[50] : t.palette.grey[900],
            backgroundSize: 'cover',
            backgroundPosition: 'center',
          }}
        />
        <Grid item xs={12} sm={8} md={5} component={Paper} elevation={6} square>
          <Box
            sx={{
              my: 8,
              mx: 4,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
            }}
          >
            <Avatar sx={{ m: 1, bgcolor: 'primary.main' }}>
              <LockOutlinedIcon />
            </Avatar>
            <Typography component="h1" variant="h5">
              Sign in
            </Typography>
            <Box component="form" noValidate onSubmit={handleSubmit} sx={{ mt: 1 }}>
              <TextField
                margin="normal"
                required
                fullWidth
                id="email"
                label="Email Address"
                name="email"
                autoComplete="email"
                autoFocus
              />
              <TextField
                margin="normal"
                required
                fullWidth
                name="password"
                label="Password"
                type="password"
                id="password"
                autoComplete="current-password"
              />
              <Button
                type="submit"
                fullWidth
                variant="contained"
                sx={{ mt: 3, mb: 2 }}
              >
                Sign In
              </Button>
              <Stack>
                <CircularProgress
                  sx={{
                    visibility: isLoadingAuthReq ? 'visibile' : 'hidden',
                    margin: 'auto',
                    marginBottom: '5%',
                    width: '50%' 
                  }}
                />
              
              <Alert severity="error" sx={{
                visibility: authReqHadError ? 'visible' : 'hidden'
              }}>
                {authReqErrorMsg}
              </Alert>
              </Stack>
              <Copyright sx={{ mt: 5 }} />
            </Box>
          </Box>
        </Grid>
      </Grid>
    </ThemeProvider>
  );
}
