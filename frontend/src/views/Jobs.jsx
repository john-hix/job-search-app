import * as React from 'react';


import MuiDrawer from '@mui/material/Drawer';

import MuiAppBar from '@mui/material/AppBar';

import Grid from '@mui/material/Grid';
import Paper from '@mui/material/Paper';

export default function Dashboard() {
  return (
    <>
      <Grid container spacing={3}>
        {/* Chart */}
        <Grid item xs={12} md={8} lg={9}>
          <Paper
            sx={{
              p: 2,
              display: 'flex',
              flexDirection: 'column',
              height: 240,
            }}
          >
            <p>Some list of jobs or something</p>
          </Paper>
        </Grid>
        {/* Recent Deposits */}
        <Grid item xs={12} md={4} lg={3}>
          <Paper
            sx={{
              p: 2,
              display: 'flex',
              flexDirection: 'column',
              height: 240,
            }}
          >
            <p>This is a jobs list or something</p>
          </Paper>
        </Grid>
        {/* Recent Orders */}
        <Grid item xs={12}>
          <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column' }}>
          <p>More stuff about jobs</p>
          </Paper>
        </Grid>
      </Grid>


    </>

  );
}

