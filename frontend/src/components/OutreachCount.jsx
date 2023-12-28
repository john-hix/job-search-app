import * as React from 'react';
import Typography from '@mui/material/Typography';
import Title from './Title';

export default function OutreachCount() {
  return (
    <React.Fragment>
      <Title>Network touches</Title>
      <Typography component="p" variant="h4">
        2
      </Typography>
      <Typography color="text.secondary" sx={{ flex: 1 }}>
        Past 30 days
      </Typography>
    </React.Fragment>
  );
}
