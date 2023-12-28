import * as React from 'react';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import ListSubheader from '@mui/material/ListSubheader';
import DashboardIcon from '@mui/icons-material/Dashboard';
import BriefcaseIcon from '@mui/icons-material/Work';
import PeopleIcon from '@mui/icons-material/People';
import TaskIcon from '@mui/icons-material/Task';
import KanbanIcon from '@mui/icons-material/ViewKanban';
import AssignmentIcon from '@mui/icons-material/Assignment';
import { Link as RouterLink } from 'react-router-dom';


export const mainListItems = (
  <React.Fragment>
    <ListItemButton component={RouterLink} to={'/'}>
      <ListItemIcon>
        <DashboardIcon />
      </ListItemIcon>
      <ListItemText primary="Dashboard" />
    </ListItemButton>
    <ListItemButton component={RouterLink} to={'/kanban'}>
      <ListItemIcon>
        <KanbanIcon />
      </ListItemIcon>
      <ListItemText primary="Kanban" />
    </ListItemButton>
    <ListItemButton component={RouterLink} to={'/tasks'}>
      <ListItemIcon>
        <TaskIcon />
      </ListItemIcon>
      <ListItemText primary="Tasks" />
    </ListItemButton>
    <ListItemButton component={RouterLink} to={'/jobs'}>
      <ListItemIcon>
        <BriefcaseIcon />
      </ListItemIcon>
      <ListItemText primary="Jobs" />
    </ListItemButton>
    <ListItemButton component={RouterLink} to={'/contacts'}>
      <ListItemIcon>
        <PeopleIcon />
      </ListItemIcon>
      <ListItemText primary="Contacts" />
    </ListItemButton>
  </React.Fragment>
);

export const secondaryListItems = (
  <React.Fragment>
    <ListSubheader component="div" inset>
      Saved reports
    </ListSubheader>
    <ListItemButton>
      <ListItemIcon>
        <AssignmentIcon />
      </ListItemIcon>
      <ListItemText primary="Current month" />
    </ListItemButton>
    <ListItemButton>
      <ListItemIcon>
        <AssignmentIcon />
      </ListItemIcon>
      <ListItemText primary="Last quarter" />
    </ListItemButton>
    <ListItemButton>
      <ListItemIcon>
        <AssignmentIcon />
      </ListItemIcon>
      <ListItemText primary="Year-end sale" />
    </ListItemButton>
  </React.Fragment>
);
