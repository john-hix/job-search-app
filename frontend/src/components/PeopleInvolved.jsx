import * as React from 'react';
import Typography from '@mui/material/Typography';
import Title from './Title';

export default function PeopleInvolved() {
  return (
    <React.Fragment>
      <Title>People involved</Title>
      <Typography component="p" variant="h4">
        14
      </Typography>
      <Typography color="text.secondary" sx={{ flex: 1 }}>
        In current job search
      </Typography>
    </React.Fragment>
  );
}
