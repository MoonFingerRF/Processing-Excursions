# Optics

This code simulates an entire optical table using fourier optics. In this example, a schlieren imaging setup is simulated for a gaussian phase perturbation along the x axis. A light source illuminates the phase perturbation, then that light is reflected through a parabolic reflector. The light at the focal point of the reflector is then cut by a knife edge to cause phase perturbations to be visible as amplitude variations. Then the image plane is placed one more focal length further back to obtain the schlieren image.

The optical components and propagation through free space are all modeled as filters on a complex field. The final image is obtained by propagating the light source through these filters, and the amplitude squared ends up as the detected image.


![schl_img](https://github.com/MoonFingerRF/Processing-Excursions/assets/129696982/9bd7139a-f2dc-49e4-a072-37f72189111f)
