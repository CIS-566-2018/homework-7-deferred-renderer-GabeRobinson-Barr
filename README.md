# Project 7: Deferred Renderer

Git Pages link:
https://gaberobinson-barr.github.io/homework-7-deferred-renderer-GabeRobinson-Barr/

For this hw I implemented Bloom, depth of field, and pointilism.
You can turn pointilism on or off by checking the box in the gui.
In the background a sun/moon rotates and is also the source of light in the scene. This is achieved by just altering the light direction to match the location of the sun/moon in deferred-renderer.glsl
The time attribute can be frozen also using the gui to stop the sun/moon where it is.

This will make it much easier to see the effects of the bloom effect.

The depth of field only applies to the models in the scene, in this case Mario. The camera's focus is centered on its target, so to see the effects of the depth of field blur you should pan mario to the left or right, and rotate until he is behind the center of the scene.
The shader is implemented by using a Gaussian blur with a radius that increases the further from the center of the scene the model is.
Instead of doing a 2d blur I instead did 2 1D blurs, first in the x, then the y direction. This isn't a perfect replacement for a 2D blur, but renders much faster than doing a 2D blur and looks fine for most blur radii.
I looked at wikipedia a bunch to get the formulas for standard deviation and gaussian blur.

The bloom shader is done by running a bloom pre-pass that renders a texture of only the colors that pass the light intensity threshold, and a copy of the original scene to the bloom shader.
The bloom shader then takes the threshold render, blurs it using the same technique as the depth of field shader, but with a fixed blur radius, and adds it to the original scene.

The pointilism shader is not particularly good/artistic, but you can clearly see the pointilism version of the scene.
To implement it I just generated a random number, clamped it to [0.05, 0.95], and said that if the largest component of color was lower than the random number the pixel renders black, otherwise it renders white.
I clamped the random number so that there weren't any points that would stay black/white no matter what.
This shader makes it a bit hard to see the other effects so I'd suggest turning it off most of the time.