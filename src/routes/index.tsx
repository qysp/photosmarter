import { Title } from '@solidjs/meta';
import { Toaster, ToastOptions } from 'solid-toast';
import Scan from '~/components/Scan/Scan';
import './index.css';

const toastOptions: ToastOptions = {
  style: {
    background: 'var(--toast-color-bg)',
    color: 'var(--toast-color--text)',
  },
  iconTheme: {
    secondary: 'var(--toast-color-bg)',
  },
};

export default () => {
  return (
    <>
      <header class="header">
        <Title>Photosmarter</Title>
        <h1 class="title">Photosmarter</h1>
      </header>
      <main class="content">
        <Toaster position="bottom-center" toastOptions={toastOptions} />
        <section>
          <Scan />
        </section>
      </main>
    </>
  );
};
