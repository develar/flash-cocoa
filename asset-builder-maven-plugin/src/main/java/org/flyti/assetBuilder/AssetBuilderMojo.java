package org.flyti.assetBuilder;

import org.apache.maven.artifact.Artifact;
import org.apache.maven.model.Resource;
import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.project.MavenProject;

import java.io.*;
import java.util.*;

/**
 * @goal generate
 * @phase generate-sources
 * @requiresDependencyResolution compile
 * <p/>
 * При поиске мы формируем имя согласно key + "." + имя состояния. пока что считаем что список состояний равен "off, on".
 */
public class AssetBuilderMojo extends AbstractMojo {
  /**
   * @parameter expression="${asset.builder.skip}"
   */
  @SuppressWarnings({"UnusedDeclaration"})
  private boolean skip;

  /**
   * @parameter expression="${project}"
   * @required
   * @readonly
   */
  @SuppressWarnings({"UnusedDeclaration"})
  private MavenProject project;

  /**
   * @parameter default-value="${project.build.directory}/assets"
   */
  @SuppressWarnings({"UnusedDeclaration"})
  private File output;

  /**
   * @parameter default-value="src/main/resources/assets.yml"
   */
  @SuppressWarnings({"UnusedDeclaration"})
  private File descriptor;

  private List<File> sources;

  /**
   * @parameter
   */
  @SuppressWarnings({"UnusedDeclaration"})
  private File[] inputs;

  @Override
  public void execute() throws MojoExecutionException, MojoFailureException {
    if (skip) {
      getLog().warn("Skipping generate assets");
      return;
    }

    if (!descriptor.exists()) {
      getLog().warn("Can't find assets descriptor");
      return;
    }

    try {
      setUpImageDirectories();
    }
    catch (Exception e) {
      throw new MojoExecutionException("Can't set up images source directories", e);
    }

    new AssetBuilder(descriptor, output, sources);
  }

  private void setUpImageDirectories() throws IOException, ClassNotFoundException {
    if (inputs != null) {
      sources = Arrays.asList(inputs);
      return;
    }

    sources = new ArrayList<File>();
    //noinspection unchecked
    for (Resource resource : project.getResources()) {
      sources.add(new File(resource.getDirectory()));
    }

    final Map<String, String> projectResourceDirectoryMap;
    final File projectResourceDirectoryCache = new File(project.getBuild().getDirectory(), "projectResourceDirectoryMap");
    if (projectResourceDirectoryCache.exists()) {
      //noinspection unchecked
      projectResourceDirectoryMap = (Map<String, String>) new ObjectInputStream(new FileInputStream(projectResourceDirectoryCache)).readObject();
    }
    else {
      projectResourceDirectoryMap = new HashMap<String, String>();
    }

    Map<String, MavenProject> projectReferences = project.getProjectReferences();
    for (Artifact artifact : project.getArtifacts()) {
      if ("swc".equals(artifact.getType())) {
        final String referenceProjectId = getProjectReferenceId(artifact.getGroupId(), artifact.getArtifactId(), artifact.getVersion());
        final File referenceResourceDirectory;
        if (projectResourceDirectoryMap.containsKey(referenceProjectId)) {
          referenceResourceDirectory = new File(projectResourceDirectoryMap.get(referenceProjectId));
          if (!referenceResourceDirectory.exists()) {
            projectResourceDirectoryMap.remove(referenceProjectId);
            continue;
          }
        }
        else {
          MavenProject referenceProject = projectReferences.get(referenceProjectId);
          if (referenceProject == null) {
            continue; // пока что только берем из resource directories, но swc не парсим
          }
          referenceResourceDirectory = new File(referenceProject.getResources().get(0).getDirectory());
          if (referenceResourceDirectory.exists()) {
            projectResourceDirectoryMap.put(referenceProjectId, referenceResourceDirectory.getAbsolutePath());
          }
          else {
            continue;
          }
        }

        sources.add(referenceResourceDirectory);
      }
    }

    if (!projectResourceDirectoryMap.isEmpty()) {
      //noinspection ResultOfMethodCallIgnored
      projectResourceDirectoryCache.getParentFile().mkdirs();
      new ObjectOutputStream(new FileOutputStream(projectResourceDirectoryCache)).writeObject(projectResourceDirectoryMap);
    }
  }

  private static String getProjectReferenceId(String groupId, String artifactId, String version) {
    StringBuilder buffer = new StringBuilder(128);
    buffer.append(groupId).append(':').append(artifactId).append(':').append(version);
    return buffer.toString();
  }
}