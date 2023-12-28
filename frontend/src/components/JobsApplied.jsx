import * as React from 'react';
import Typography from '@mui/material/Typography';
import Title from './Title';
import getMonday from '../util/get-monday';

const monday = getMonday(new Date());

export default function JobsApplied() {
  return (
    <React.Fragment>
      <Title>Applications</Title>
      <Typography component="p" variant="h4">
        0
      </Typography>
      <Typography color="text.secondary" sx={{ flex: 1 }}>
        Week of {monday.toDateString()}
      </Typography>
    </React.Fragment>
  );
}
