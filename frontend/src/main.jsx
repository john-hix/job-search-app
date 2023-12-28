import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import Jobs from './views/Jobs.jsx'
import '@fontsource/roboto/300.css';
import '@fontsource/roboto/400.css';
import '@fontsource/roboto/500.css';
import '@fontsource/roboto/700.css';
import './index.css'

import {
  createBrowserRouter,
  RouterProvider,
} from "react-router-dom";
import Dashboard from './Dashboard.jsx';
import SignInSide from './views/SignInSide.jsx'

// TODO: structure of components
const router = createBrowserRouter([
  {
    path: "/",
    element: <App view={Dashboard} title={'Dashboard'} />,
  },
  {
    path: "/login",
    element: <SignInSide />  // TODO
  },
  {
    path: "/kanban",
    element: <App view={() => <p>You were expecting something here?</p>} title={'Kanban'}/>
  },
  {
    path: "/tasks",
    element: <App view={() => <p>You were expecting something here?</p>} title={'Tasks'}/>
  },
  {
    path: "/jobs",
    element: <App view={Jobs} title={'Jobs'}/>
  },
  {
    path: "/contacts",
    element: <App view={() => <p>You were expecting something here?</p>} title={'Contacts'} />
  },
  {
    path: "/companies",
    element: <App view={() => <p>You were expecting something here?</p>} title={'Companies'}/>
  }
]);

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
     <RouterProvider router={router} />
  </React.StrictMode>,
)
