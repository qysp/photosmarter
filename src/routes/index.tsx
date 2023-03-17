import { Title } from 'solid-start';
import Scan from '~/components/Scan/Scan';
import './index.css';

export default () => {
  return (
    <>
      <header>
        <Title>Photosmarter</Title>
        <h1>Photosmarter</h1>
      </header>
      <main>
        <section>
          <Scan />
        </section>
      </main>
    </>
  );
};
