import * as React from 'react';


import MuiDrawer from '@mui/material/Drawer';

import MuiAppBar from '@mui/material/AppBar';

import Grid from '@mui/material/Grid';
import Paper from '@mui/material/Paper';

import Chart from './Chart';
import Deposits from './Deposits';
import Orders from './Orders';
import JobsApplied from './components/JobsApplied';
import PeopleInvolved from './components/PeopleInvolved';
import OutreachCount from './components/OutreachCount';
import InterviewList from './components/InterviewListNext14Days';
import TaskListNext14Days from './components/TaskListNext14Days';

export default function Dashboard() {
  return (
    <>
      <Grid container spacing={3}>
        <Grid item xs={12} md={4} lg={3}>
          <Paper
            sx={{
              p: 2,
              display: 'flex',
              flexDirection: 'column',
              height: 150,
            }}
          >
            <JobsApplied />
          </Paper>
        </Grid>
        <Grid item xs={12} md={4} lg={3}>
          <Paper
            sx={{
              p: 2,
              display: 'flex',
              flexDirection: 'column',
              height: 150,
            }}
          >
            <OutreachCount />
          </Paper>
        </Grid>
        <Grid item xs={12} md={4} lg={3}>
          <Paper
            sx={{
              p: 2,
              display: 'flex',
              flexDirection: 'column',
              height: 150,
            }}
          >
            <PeopleInvolved />
          </Paper>
        </Grid>

        {/* Chart */}
        <Grid item xs={12} md={9} lg={6}>
          <Paper
            sx={{
              p: 2,
              display: 'flex',
              flexDirection: 'column',
              height: 300
            }}
          >
            <InterviewList height={280}/>
          </Paper>
        </Grid>
        {/* Interviews next 15 days */}
        <Grid item xs={12} md={9} lg={6}>
          <Paper
            sx={{
              p: 2,
              display: 'flex',
              flexDirection: 'column',
              height: 300
            }}
          >
            <TaskListNext14Days height={280} />
          </Paper>
        </Grid>
        {/* Tasks next 15 days */}
        <Grid item xs={12} md={6} lg={12}>
          <Paper
            sx={{
              p: 2,
              display: 'flex',
              flexDirection: 'column',
              height: 240,
            }}
          >
            <Chart />
          </Paper>
        </Grid>
        {/* Recent Deposits */}

        {/* Recent Orders */}
        <Grid item xs={12}>
          <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column' }}>
            <Orders />
          </Paper>
        </Grid>
      </Grid>


    </>

  );
}
